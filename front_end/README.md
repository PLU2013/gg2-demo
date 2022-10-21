# Greengrocery

A new Flutter project for purchasing in group.

### Warning

This project is only a **demo**. Has no other purpose.

This demo is not functional.

## Preliminary

This app is soported in a backend that runs the API services, websocket services and interface with the data base.

The backend will not be covered here.

## Greengrocery HomePage

This page show an users list conformed with a ListView of ListTile widgets.

The status online offline is showed though a green dot over the user image and an emoji icon reflects the general status.

Also has a Drawer to navigate to:

- User Logout
- Total Order (to purchasing)
- Deal out
- Products Management
- Reset
- Exit

Tapping in each navegates to the user's page.

> Each user can only edit his own page.

### Home page views

<div display='flex' flex-direction='row'>
    <img src='/front_end/assets/images/home_page.png' alt='Home Page' height='500' style='margin:0px 20px' >
    <img src='/front_end/assets/images/drawer.png' alt='Drawer' height='500'  style='margin:0px 20px'>
</div>

---

## User's page

This page shows the user's order. Each item can be edited in quantity (buttons) or deleted by swipe right.

Users can add products that are not in their list via add button. This action navigates to Add Products Page where it displays all available products that are not on the user's list.

The save button saves the edited order on the server.

The slide button, order ready, comfirms that the order is ready.

### User page views

<div display='flex' flex-direction='row'>
    <img src='/front_end/assets/images/user_page.png' alt='User Page' height='500' style='margin:0px 20px' >
    <img src='/front_end/assets/images/add_products_page.png' alt='Add Product Page' height='500'  style='margin:0px 20px'>
</div>

___

## Purchasing page

This page is only used for the purchaser or admin user. It's the shopping list. Here was used a DataTable widget.

Here, the buyer can mark each product purchased, can edit the product price and priority.

> The priority number defines the purchasing priority according the buyer's preferences. 
>> This value can also be edited in the product management page.

### Buyer page views

<div display='flex' flex-direction='row'>
    <img src='/front_end/assets/images/buyer_page.png' alt='Buyer Page' height='500' style='margin:0px 20px' >
    <img src='/front_end/assets/images/buyer_page_edit_dialog.png' alt='Buyer Page Edit Dialog Box' height='500'  style='margin:0px 20px'>
</div>

---

## Product management page

This page is only used for the purchaser or admin user.

Here is a DataTable where products can be added, edited and deleted. 

All the changes are saved on the server.

### Products management page view

<img src='/front_end/assets/images/products_management_page.png' alt='Products Management Page' height='500' style='margin:0px 20px' >