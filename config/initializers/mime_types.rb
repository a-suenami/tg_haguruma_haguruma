# Windows でアップロードされる zip ファイルが application/x-zip-compressed になってしまうため application/zip の synonyms を設定
Mime::Type.register('application/zip', :zip, ['application/x-zip-compressed'])