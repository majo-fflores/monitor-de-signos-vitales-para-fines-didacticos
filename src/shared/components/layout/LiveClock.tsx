import { useEffect, useState } from 'react';

export function LiveClock() {
  const [currentTime, setCurrentTime] = useState(() => new Date());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const formattedDate = currentTime.toLocaleDateString('es-ES', {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  const formattedTime = currentTime.toLocaleTimeString('es-ES', {
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  });

  return (
    <div className="text-right flex flex-col justify-center">
      <span className="text-sm font-semibold text-foreground tracking-tight transition-colors duration-200">
        {formattedDate}
      </span>
      <span className="text-xs text-muted-foreground font-mono transition-colors duration-200 mt-0.5">
        {formattedTime}
      </span>
    </div>
  );
}
