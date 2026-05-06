import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { AlertsView } from './features/alerts/components/AlertsView';
import { DashboardView } from './features/dashboard/components/DashboardView';
import { HistoryView } from './features/history/components/HistoryView';
import { SettingsView } from './features/settings/components/SettingsView';
import { MainLayout } from './shared/components/layout/MainLayout';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<MainLayout />}>
          <Route index element={<DashboardView />} />
          <Route path="historial" element={<HistoryView />} />
          <Route path="alertas" element={<AlertsView />} />
          <Route path="configuracion" element={<SettingsView />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
