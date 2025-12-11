# SkaagPay Admin Panel

A Flutter-based Admin Panel for SkaagPay, backed by a Django API and Supabase PostgreSQL.

## 🚀 Key Workflows

### 🔐 Login Pipeline
The authentication system supports identity verification.
*   **Credentials**: Phone Number + Password.
*   **Identity**: **Full Name** is required.

**Login Payload (`POST /api/admin/login/`)**
```json
{
    "phone_number": "9999999999",
    "password": "yourpassword",
    "full_name": "Admin Name"
}
```

### 💰 TopUp Management Pipeline
Replaces image verification with Transaction Reference.

**TopUp Creation Payload (`POST /api/wallet/topup/`)**
*(Used by Client App, Admin views this data)*
```json
{
    "amount": "500.00",
    "transaction_reference": "1234"
}
```
*Note: `screenshot` field has been removed.*

**TopUp Action Payload (`POST /api/admin/topups/{id}/action/`)**
```json
{
    "action": "APPROVE", 
    "note": "Verified with Bank"
}
```

### 👥 User & Recharge Management
*   **User Control**: Toggle User Active status.
*   **Recharge Updates**: Manual status override.

**Recharge Update Payload (`PATCH /api/admin/recharges/{id}/`)**
```json
{
    "status": "SUCCESS"
}
```

---

## 🛠 Backend Setup (Django)

1.  **Navigate**: `cd skaagpayBackend`
2.  **Dependencies**: `pip install -r requirements.txt`
3.  **Database**: Configured for **Supabase PostgreSQL**.
4.  **Migrations**: `python manage.py migrate`
5.  **Superuser**: `python create_superuser.py`
6.  **Run**: `python manage.py runserver`

## 📱 Frontend Setup (Flutter)

1.  **Navigate**: `cd SkaagAdminApp`
2.  **Dependencies**: `flutter pub get`
3.  **Configuration**: Check `lib/utils/constants.dart`.
4.  **Run**: `flutter run`
