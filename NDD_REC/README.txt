REM -----------------------------------------------------------------
REM - 整合 Theia NDD 以及 gStreamer 錄影功能。
REM -----------------------------------------------------------------
REM - Usages:
REM -   theia_nddREC.bat [-T n] [-S] [projDIR]
REM -
REM - 指令執行後會先做一次 NDD Dump，NDD 預設輸出目錄為 nddREC 。
REM -     指定 projDIR 參數可以變更 output directory。
-
- NDD 完成後，緊接著會錄一段 Video，預設錄影長度為 10 秒。
-     Video 會被存到 Output directory， named as theia.avi
-     指定 -T n 參數可以變更錄影長度，Example, -T 20 為 20 秒。
-
- 為了方便查看結果，NDD jpg 以及 video 會被 copy 一份到現行目錄下，
-     檔案名稱會以 output directory 相同的名稱冠名。
-     Example: theia_nddREC.bat test1
-        NDD jpg 以及 video 會被冠名為 test1.jpg 以及 test1.avi。
-     -S 參數可以取消自動 Copy 的功能，可以節省空間以及時間。
-------------------------------------------------------------------
Example:
	theia_nddREC.bat -T 30 test-001
		Camera會做以下動作:
		1. NDD Dump，並取回 NDD Dump 結果，存在 test-001 目錄下。
		2. NDD Dump 結束後錄影 30 sec，錄影檔存在 test-001 目錄下。
		3. test-001 目錄下的 jpeg 以及 avi 檔會 copy 一份到現行目錄，
			分別命名為 test-001.jpeg 以及 test-001.avi 方便查看。
--------------------------------------------------------------------
NOTE:
	記得在開機後，要先 login 到 camera (UART console)，
	執行以下指令一次 :

		mount -o remount,rw  /
		mkdir -p /sdcard/camera_dump/
		cct_camera_server &

	


