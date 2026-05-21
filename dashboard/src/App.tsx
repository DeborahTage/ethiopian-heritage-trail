import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { LoginPage } from './features/auth/LoginPage';
import { RequireAuth } from './components/layout/RequireAuth';
import { MainLayout } from './components/layout/MainLayout';

import { LandmarkListPage } from './features/landmarks/LandmarkListPage';
import { LandmarkCreatePage } from './features/landmarks/LandmarkCreatePage';
import { LandmarkEditPage } from './features/landmarks/LandmarkEditPage';
import { LandmarkStatsPage } from './features/landmarks/LandmarkStatsPage';
import { ContentEditorPage } from './features/landmarks/ContentEditorPage';

import { AnalyticsLayout } from './features/analytics/components/AnalyticsLayout';
import { OverviewPage } from './features/analytics/OverviewPage';
import { HeatmapPage } from './features/analytics/HeatmapPage';
import { FlowPage } from './features/analytics/FlowPage';
import { ReportsPage } from './features/analytics/ReportsPage';

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<LoginPage />} />

        {/* Protected Routes */}
        <Route
          path="/"
          element={
            <RequireAuth>
              <MainLayout />
            </RequireAuth>
          }
        >
          <Route index element={<Navigate to="/analytics" replace />} />
          <Route path="analytics" element={<RequireAuth allowedRoles={['ADMIN']}><AnalyticsLayout /></RequireAuth>}>
            <Route index element={<OverviewPage />} />
            <Route path="heatmap" element={<HeatmapPage />} />
            <Route path="flow" element={<FlowPage />} />
            <Route path="reports" element={<ReportsPage />} />
          </Route>
          <Route path="landmarks">
            <Route index element={<RequireAuth allowedRoles={['ADMIN', 'ORGANIZER']}><LandmarkListPage /></RequireAuth>} />
            <Route path="create" element={<RequireAuth allowedRoles={['ADMIN', 'ORGANIZER']}><LandmarkCreatePage /></RequireAuth>} />
            <Route path=":id/edit" element={<RequireAuth allowedRoles={['ADMIN', 'ORGANIZER']}><LandmarkEditPage /></RequireAuth>} />
            <Route path=":id/content" element={<RequireAuth allowedRoles={['ADMIN', 'ORGANIZER']}><ContentEditorPage /></RequireAuth>} />
            <Route path=":id/stats" element={<RequireAuth allowedRoles={['ADMIN', 'ORGANIZER']}><LandmarkStatsPage /></RequireAuth>} />
          </Route>
        </Route>
      </Routes>
    </Router>
  );
};

export default App;
