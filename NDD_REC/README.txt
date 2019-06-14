REM -----------------------------------------------------------------
REM - 整合 Theia NDD 以及 gStreamer 錄影功能。
REM -----------------------------------------------------------------
REM - Usages:
REM -   theia_nddREC.bat [-T n] [-S] [projDIR]
REM -
REM - 指令執行後會先做一次 NDD Dump，NDD 預設輸出目錄為 nddREC 。
REM -     指定 projDIR 參數可以變更 output directory。
REM -
REM - NDD 完成後，緊接著會錄一段 Video，預設錄影長度為 10 秒。
REM -     Video 會被存到 Output directory， named as theia.avi
REM -     指定 -T n 參數可以變更錄影長度，Example, -T 20 為 20 秒。
REM -
REM - 為了方便查看結果，NDD jpg 以及 video 會被 copy 一份到現行目錄下，
REM -     檔案名稱會以 output directory 相同的名稱冠名。
REM -     Example: theia_nddREC.bat test1
REM -        NDD jpg 以及 video 會被冠名為 test1.jpg 以及 test1.avi。
REM -     -S 參數可以取消自動 Copy 的功能，可以節省空間以及時間。
REM -------------------------------------------------------------------