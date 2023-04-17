# base_project

Alo ninja

## Các folder
- Common: chứa nhưng thành phần dùng chung ở tất cả các nơi
- Config: chứa các phần setting vd: font,routes,values, ...
- Models: chứa các thực thể
- Screens: nơi để các file liên quan đến thành phần hiển thị lên màn hình
- Services: nơi kết nối để lấy data từ server hoặc data local
- File : + environment: các môi trường vd: dev,prod
         +  my_app: chạy sau hàm main
## Nghiệm vụ
- Lịch sư cuộc gọi sẽ được đồng bộ lần đầu từ 8h ngày tải app, nhưng lần đồng bộ sau đó sẽ được được lấy môc
là thời gian đồng bộ thành công của lần đồng bộ lần trước
- Luồng offline: hiện thị được danh và chi tiết cuộc gọi giống vs luồng online hiện thị danh sách phân chia ngày, chi tiết.
của lcihj sử cuộc gọi.
- Gọi qua deeplink khi offline: các cuộc gọi sẽ được đồng khi có mạng và đồng bộ đơn hàng lên server thoả mãn
điều kiện sô điện thoại gọi qua deeplink chùng vs sdt của call log và nhỏ hơn 2h

## Lưu ý: 
- App được quản lý state bằng getx hạn chế sửa dụng setState vì nó sẽ rebuild lại widget ảnh hướng tới performan
- Những tài nguyên nào khi khai báo ra kết thúc vòng đời mà ko sử dụng đến thì giải phóng chánh làm tốn tài nguyên RAM