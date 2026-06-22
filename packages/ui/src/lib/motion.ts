import type { Transition, Variants } from "motion/react";

const ease = [0.22, 1, 0.36, 1] as const;
export const nodeTransition: Transition = { duration: 0.2, ease };
export const nodeMotion: Variants = { resting: { scale: 1, opacity: 0.86 }, active: { scale: 1.04, opacity: 1 }, pressed: { scale: 0.97 } };
export const threadMotion: Variants = { resting: { opacity: 0.45 }, active: { opacity: 1, transition: { duration: 0.42, ease } }, dimmed: { opacity: 0.18 } };
export const particleMotion: Variants = { drift: { y: [0, -5, 0], x: [0, 2, 0], transition: { duration: 18, repeat: Infinity, ease: "easeInOut" } } };
export const reducedMotion = { node: { transition: { duration: 0.1 } }, central: { transition: { duration: 0.1 } }, thread: { transition: { duration: 0.1 } } } as const;
