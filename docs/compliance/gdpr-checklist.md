# GDPR Compliance Checklist

> Heti CI pipeline-ban automatizaltan ellenorizzuk.

## Adatkezeles
- [ ] PII scanner fut (email/phone/SSN detect kodban)
- [ ] Data retention policy betartva (>2 ev → auto delete)
- [ ] Cookie consent audit (frontend crawl)
- [ ] Data export endpoint tesztje zold (right to portability)
- [ ] Data deletion endpoint tesztje zold (right to erasure)
- [ ] Third-party data sharing audit (minden external API)

## Jogalapok
- [ ] Minden adatkezeles jogalapja dokumentalt
- [ ] Hozzajarulas-kezeles (consent management) mukodik
- [ ] Adatfeldolgozoi szerzodes (DPA) minden harmadik felen

## Technikai vedelem
- [ ] Titkositas at-rest (PostgreSQL, MinIO, backup)
- [ ] Titkositas in-transit (TLS mindenhol)
- [ ] Pseudonimizalas szemelyazonositasra alkalmas adatokon
- [ ] Hozzaferes naplozva (activity log)

## Szervezeti
- [ ] Adatvedelmi tisztviselo (DPO) kijelolve
- [ ] Adatvedelmi hatasvizsgalat (DPIA) elvegezve
- [ ] Incidens-kezelesi terv aktualis

## Riport
- Heti riport → compliance officer email
- Anomalia → Slack #compliance + Jira ticket
