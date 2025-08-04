PERIODIC_JOBS = ->(mgr) {
  mgr.register '43 * * * *',       Auth::ExpireSessionTokensWorker.name                      # 毎時43分に実行
  mgr.register '15 * * * *',       Reception::TriggerSendResultAnnouncementEmailsWorker.name # 毎時15分に実行
  mgr.register '*/5 * * * *',      Act::TriggerIssueTicketsWorker.name                       # 5分ごとに実行
  mgr.register '0 2,7 * * *',      KomojuRecord::TriggerCaptureWorker.name                   # 午前2時と午前7時に実行
  mgr.register '10 * * * *',       Reception::ReleaseInstancesOfUnpaidEntriesWorker.name     # 毎時10分に実行
  mgr.register '1 * * * *',        Resale::TriggerLotteriesWorker.name                       # 毎時01分に実行
  mgr.register '15 * * * *',       Resale::ReleaseLockedInstancesWorker.name                 # 毎時15分に実行
  mgr.register '*/15 * * * *',     Resale::SendFixedEmailsWorker.name                        # 15分ごとに実行
  mgr.register '15 * * * *',       Resale::TriggerSendLostEmailsWorker.name                  # 毎時15分に実行
  mgr.register '15 * * * *',       Resale::TriggerSendNotFixedEmailsWorker.name              # 毎時15分に実行
  mgr.register '5,35 * * * *',     GmoRemittanceRecord::SyncRemittancesWorker.name           # 毎時5分と35分に実行
  mgr.register '0 * * * *',        CrawlDeploymentInfoWorker.name                            # 毎時00分に実行
  mgr.register '0 12-17 * * *',    User::UpdateHamadashogoBlacklistsWorker.name              # 12~17時に実行
}
