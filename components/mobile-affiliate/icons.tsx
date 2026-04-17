import { SVGProps } from "react";

type IconProps = SVGProps<SVGSVGElement>;

export function GridIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <rect x="4" y="4" width="6" height="6" rx="1.2" />
      <rect x="14" y="4" width="6" height="6" rx="1.2" />
      <rect x="4" y="14" width="6" height="6" rx="1.2" />
      <rect x="14" y="14" width="6" height="6" rx="1.2" />
    </svg>
  );
}

export function FlameIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M12 3c2 2.2 4 4.8 4 8a4 4 0 1 1-8 0c0-1.8.8-3.3 2.2-4.9.2 1.6 1 2.5 1.8 3.1C12.7 7 12.5 5.1 12 3Z" />
      <path d="M12 13.8c1.1.8 1.8 1.8 1.8 3a1.8 1.8 0 1 1-3.6 0c0-.8.4-1.5 1-2.2.2.8.5 1.2.8 1.5Z" />
    </svg>
  );
}

export function LinkIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M10 14 8.2 15.8a3 3 0 1 1-4.2-4.2L7 8.6" />
      <path d="m14 10 1.8-1.8a3 3 0 0 1 4.2 4.2L17 15.4" />
      <path d="m8.5 15.5 7-7" />
    </svg>
  );
}

export function TrophyIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M8 4h8v3a4 4 0 0 1-8 0V4Z" />
      <path d="M6 5H4a2 2 0 0 0 2 4h1" />
      <path d="M18 5h2a2 2 0 0 1-2 4h-1" />
      <path d="M12 11v4" />
      <path d="M9 21h6" />
      <path d="M10 15h4a2 2 0 0 1-4 0Z" />
    </svg>
  );
}

export function NetworkIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <circle cx="6" cy="7" r="2.5" />
      <circle cx="18" cy="7" r="2.5" />
      <circle cx="12" cy="17" r="2.5" />
      <path d="M8.2 8.4 10.7 14" />
      <path d="M15.8 8.4 13.3 14" />
    </svg>
  );
}

export function WalletIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <rect x="3" y="6" width="18" height="12" rx="2" />
      <path d="M16 12h3" />
      <path d="M6 9h8" />
    </svg>
  );
}

export function BellIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M6 10a6 6 0 1 1 12 0c0 5 2 6 2 6H4s2-1 2-6" />
      <path d="M10 20a2 2 0 0 0 4 0" />
    </svg>
  );
}

export function ShieldIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M12 3 5 6v6c0 4 3 7 7 9 4-2 7-5 7-9V6l-7-3Z" />
      <path d="m9 12 2 2 4-4" />
    </svg>
  );
}

export function ListIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M9 6h11" />
      <path d="M9 12h11" />
      <path d="M9 18h11" />
      <circle cx="4" cy="6" r="1" fill="currentColor" stroke="none" />
      <circle cx="4" cy="12" r="1" fill="currentColor" stroke="none" />
      <circle cx="4" cy="18" r="1" fill="currentColor" stroke="none" />
    </svg>
  );
}

export function CoinIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M7 12h10" />
      <path d="M12 7c-2.8 0-5 2.2-5 5s2.2 5 5 5" />
      <path d="M12 7c2.8 0 5 2.2 5 5s-2.2 5-5 5" />
    </svg>
  );
}

export function LogoutIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M10 17l-5-5 5-5" />
      <path d="M5 12h10" />
      <path d="M14 5h3a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2h-3" />
    </svg>
  );
}

export function ArrowLeftIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="m15 18-6-6 6-6" />
    </svg>
  );
}

export function PencilIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="m4 20 4.5-1 9-9a2.1 2.1 0 0 0-3-3l-9 9L4 20Z" />
      <path d="m13.5 6.5 4 4" />
    </svg>
  );
}

export function RocketIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M14 4c3.5 0 6 2.5 6 6-2 3-5.5 6-10 8-1-4.5 2-8 4-10Z" />
      <path d="M10 14 6 18" />
      <path d="M9 5 5 9" />
      <circle cx="15.5" cy="8.5" r="1.5" />
    </svg>
  );
}

export function SparklesIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="m12 3 1.8 4.2L18 9l-4.2 1.8L12 15l-1.8-4.2L6 9l4.2-1.8L12 3Z" />
      <path d="m19 14 .9 2.1L22 17l-2.1.9L19 20l-.9-2.1L16 17l2.1-.9L19 14Z" />
      <path d="m5 15 .7 1.6L7.3 17l-1.6.7L5 19.3l-.7-1.6L2.7 17l1.6-.7L5 15Z" />
    </svg>
  );
}

export function ShareIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <circle cx="18" cy="5" r="2.5" />
      <circle cx="6" cy="12" r="2.5" />
      <circle cx="18" cy="19" r="2.5" />
      <path d="m8.2 10.9 7.4-4.2" />
      <path d="m8.2 13.1 7.4 4.2" />
    </svg>
  );
}

export function DownloadIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <path d="M12 4v10" />
      <path d="m8 10 4 4 4-4" />
      <path d="M5 19h14" />
    </svg>
  );
}

export function MouseIcon(props: IconProps) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.9" {...props}>
      <rect x="7" y="3" width="10" height="18" rx="5" />
      <path d="M12 7v3" />
    </svg>
  );
}
