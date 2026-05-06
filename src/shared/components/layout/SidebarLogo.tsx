export function SidebarLogo() {
  return (
    <div className="w-14 h-14 flex items-center justify-center transition-all duration-200">
      <img
        src="/isotipo-light.svg"
        alt="DataVital Isotipo"
        className="w-full h-full object-contain dark:hidden"
      />
      <img
        src="/isotipo-dark.svg"
        alt="DataVital Isotipo"
        className="w-full h-full object-contain hidden dark:block"
      />
    </div>
  );
}
