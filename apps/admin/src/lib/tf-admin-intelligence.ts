/**
 * TF.js admin intelligencia motor
 * Browser-side: felhasznaloi szint joslas, menu optimalizalas
 */

/** Felhasznaloi szint */
export type UserLevel = 'beginner' | 'intermediate' | 'expert';

/** Viselkedes feature-ok */
export interface BehaviorFeatures {
  clickCount: number;
  navigationSpeed: number; // atlag ms oldalvaltasok kozott
  searchUsage: number;     // kereses hasznalat gyakorisag
  shortcutUsage: number;   // billentyuparancs hasznalat
  sessionDuration: number; // perc
}

/** Felhasznaloi szint joslas (placeholder – TF.js model szukseges) */
export function predictUserLevel(features: BehaviorFeatures): UserLevel {
  // TODO: TF.js model betoltes es inference
  // Egyelore egyszeru heurisztika:
  if (features.shortcutUsage > 10 && features.navigationSpeed < 2000) return 'expert';
  if (features.sessionDuration > 30 && features.searchUsage > 5) return 'intermediate';
  return 'beginner';
}

/** Menu sorrend optimalizalas (leggyakrabban hasznalt elol) */
export function optimizeMenuOrder(
  menuItems: string[],
  clickHistory: Record<string, number>,
): string[] {
  return [...menuItems].sort((a, b) => (clickHistory[b] || 0) - (clickHistory[a] || 0));
}
