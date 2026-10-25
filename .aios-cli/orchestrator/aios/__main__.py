"""aios CLI: route | run | providers | budget | explain | policy-doc.

Exit kodok: 0 OK, 1 hiba, 2 nincs futtathato provider, 3 titok a promptban,
4 megerosites szukseges (--confirm), 5 policy hiba.
"""

from __future__ import annotations

import argparse
import json
import sys
import time

from .dispatch import build_command, dispatch
from .ledger import Ledger
from .policy import PolicyError, load_policy
from .providers import probe_all
from .route import Decision, route
from .secrets import find_secrets

EXIT_SECRET = 3
EXIT_CONFIRM = 4
EXIT_POLICY = 5
PERIODS = {"day": 86400, "week": 7 * 86400, "month": 30 * 86400}


def _print_decision(d: Decision) -> None:
    print(f"Tier:        {d.tier}" + (f"  (osztalyozo: {d.task_tier})" if d.task_tier != d.tier else ""))
    print(f"Adatosztaly: {d.data_class}")
    if d.requires_confirm:
        print("Megerosites: KOTELEZO (--confirm)")
    if d.parallel:
        print("Mod:         parhuzamos konszenzus (scripts/multi-vendor-consensus.sh)")
    print("Lanc:")
    for i, s in enumerate(d.chain, 1):
        extra = f" profile={s.profile}" if s.profile else ""
        print(f"  {i}. {s.provider}:{s.variant}  model={s.model} effort={s.effort}{extra}")
    if d.excluded:
        print(f"Kizarva:     {', '.join(d.excluded)}")
    print("Indoklas:")
    for r in d.reasons:
        print(f"  - {r}")


def cmd_route(args: argparse.Namespace) -> int:
    policy = load_policy()
    d = route(args.task, args.files, policy=policy, tier=args.tier)
    if args.json:
        print(json.dumps(d.to_dict(), ensure_ascii=False, indent=2))
    else:
        _print_decision(d)
    return 0


def cmd_run(args: argparse.Namespace) -> int:
    found = find_secrets(args.task)
    if found:
        sys.stderr.write(f"[aios] MEGALLITVA: titok a promptban ({', '.join(found)}). Semmi nem lett elkuldve.\n")
        return EXIT_SECRET
    policy = load_policy()
    d = route(args.task, args.files, policy=policy, tier=args.tier)
    if args.provider:
        d.chain = [s for s in d.chain if s.provider == args.provider]
        if not d.chain:
            sys.stderr.write(f"[aios] '{args.provider}' nem szerepel az engedelyezett lancban ({d.tier}, {d.data_class}).\n")
            return 2
    if d.requires_confirm and not args.confirm:
        _print_decision(d)
        sys.stderr.write("[aios] Kritikus feladat: futtasd ujra --confirm kapcsoloval.\n")
        return EXIT_CONFIRM
    if d.parallel:
        sys.stderr.write("[aios] Konszenzus tier: hasznald a scripts/multi-vendor-consensus.sh scriptet.\n")
        return 2
    if args.dry_run:
        _print_decision(d)
        for s in d.chain:
            if policy.providers[s.provider].kind == "cli":
                print(f"  $ {' '.join(build_command(s, '<prompt>', policy))}")
            else:
                print(f"  POST {policy.providers[s.provider].url}/chat/completions model={s.model}")
        return 0
    result = dispatch(d, args.task, policy=policy, ledger=Ledger())
    if result.output:
        print(result.output)
    return result.exit_code


def cmd_providers(args: argparse.Namespace) -> int:
    policy = load_policy()
    rows = probe_all(policy)
    if args.json:
        print(json.dumps([r.__dict__ for r in rows], ensure_ascii=False, indent=2))
        return 0
    for r in rows:
        mark = "OK " if r.available else "-- "
        print(f"{mark} {r.provider:<9} {r.kind:<6} {r.detail}")
    return 0


def cmd_budget(args: argparse.Namespace) -> int:
    since = time.time() - PERIODS[args.period]
    summary = Ledger().summary(since)
    if not summary:
        print(f"Nincs futas az utolso idoszakban ({args.period}).")
        return 0
    print(f"{'tier / provider':<32} {'futas':>6} {'hiba':>5} {'ido (s)':>9}")
    for key, v in sorted(summary.items()):
        print(f"{key:<32} {int(v['runs']):>6} {int(v['failures']):>5} {v['duration_s']:>9.1f}")
    return 0


def cmd_explain(args: argparse.Namespace) -> int:
    policy = load_policy()
    names = [args.tier] if args.tier else list(policy.tiers)
    for name in names:
        if name not in policy.tiers:
            sys.stderr.write(f"ismeretlen tier: {name}\n")
            return 1
        t = policy.tiers[name]
        flags = (" [megerosites]" if t.requires_confirm else "") + (" [parhuzamos]" if t.parallel else "")
        print(f"{name}{flags}: {t.description}")
        for p, v in t.chain:
            var = policy.providers[p].variants[v]
            print(f"  -> {p}:{v} ({var.model}, {var.effort}) adat: {'/'.join(policy.providers[p].data_classes)}")
    return 0


def cmd_policy_doc(_: argparse.Namespace) -> int:
    """Ember-olvashato routing tabla (core/routing-policy.md generalashoz)."""
    policy = load_policy(env={})
    print("| Tier | Lanc (elso = elsodleges) | Megjegyzes |")
    print("|------|--------------------------|------------|")
    for t in policy.tiers.values():
        chain = " → ".join(f"{p}:{v} (`{policy.providers[p].variants[v].model}`)" for p, v in t.chain)
        note = t.description + ("; `--confirm` kell" if t.requires_confirm else "") + ("; párhuzamos" if t.parallel else "")
        print(f"| {t.name} | {chain} | {note} |")
    print()
    print("| Provider | Típus | Engedett adatosztály |")
    print("|----------|-------|----------------------|")
    for p in policy.providers.values():
        where = p.binary if p.kind == "cli" else p.url
        print(f"| {p.name} | {p.kind} (`{where}`) | {', '.join(p.data_classes)} |")
    return 0


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="aios", description="AIOS orchestrator: feladat -> CLI/modell routing")
    sub = parser.add_subparsers(dest="cmd", required=True)

    def task_args(p: argparse.ArgumentParser) -> None:
        p.add_argument("task", help="a feladat szovege")
        p.add_argument("--files", nargs="*", default=[], help="erintett fajlok/mappak (meret + erzekenyseg)")
        p.add_argument("--tier", help="tier kezi felulirasa")

    p = sub.add_parser("route", help="javaslat, nem indit semmit")
    task_args(p)
    p.add_argument("--json", action="store_true")
    p.set_defaults(func=cmd_route)

    p = sub.add_parser("run", help="inditas fallback lanccal")
    task_args(p)
    p.add_argument("--provider", help="csak ez a provider (ha a lanc engedi)")
    p.add_argument("--confirm", action="store_true", help="kritikus feladat megerositese")
    p.add_argument("--dry-run", action="store_true")
    p.set_defaults(func=cmd_run)

    p = sub.add_parser("providers", help="CLI-k es helyi szerverek elerhetosege")
    p.add_argument("--json", action="store_true")
    p.set_defaults(func=cmd_providers)

    p = sub.add_parser("budget", help="ledger osszesites")
    p.add_argument("--period", choices=sorted(PERIODS), default="week")
    p.set_defaults(func=cmd_budget)

    p = sub.add_parser("explain", help="tier lanc kiirasa")
    p.add_argument("tier", nargs="?")
    p.set_defaults(func=cmd_explain)

    p = sub.add_parser("policy-doc", help="markdown tabla a policy-bol")
    p.set_defaults(func=cmd_policy_doc)
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        return int(args.func(args))
    except PolicyError as exc:
        sys.stderr.write(f"[aios] policy hiba: {exc}\n")
        return EXIT_POLICY


if __name__ == "__main__":
    sys.exit(main())
