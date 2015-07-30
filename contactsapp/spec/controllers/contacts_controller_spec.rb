require 'rails_helper'

RSpec.describe ContactsController, type: :controller do

  before :all do
    @rspec_file_path = 'db/test.txt'
    delete_file
    Contact.filepath = @rspec_file_path
  end

  after :all do
    delete_file
  end

  def delete_file( file = @rspec_file_path )
    File.delete(file) if File.exists?(file)
  end

  let(:valid_attributes) { FactoryGirl.attributes_for(:contact) }

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end

    it "assigns @contacts" do
      get :index
      contact = Contact.all
      expect(assigns(:contacts)).to eq(contact)
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template("new")
    end

  end

  describe "POST #create" do
    describe "with valid params" do
      before do
        FactoryGirl.create :contact
        FactoryGirl.create :contact
      end

      it "creates a new Contact" do
        expect {
          post :create, {contact: valid_attributes}
        }.to change(Contact, :count).by(1)
      end

      it "assigns a newly created Contact as @contact" do
        post :create, {contact: valid_attributes}
        expect(assigns(:contact)).to be_a(Contact)
        expect(assigns(:contact)).to be_valid
        expect(assigns(:contact).deleted).to eq Contact::DELETED_OPTIONS[1]
      end

      it "redirects to the created Contact" do
        post :create,  {contact: valid_attributes}
        expect(response).to redirect_to(contacts_path)
      end
    end
  end

  describe "GET #show" do
    it "renders the show template" do
      contact = Contact.new valid_attributes
      contact.save
      get :show, {id: contact.to_param}
      expect(response).to render_template("show")
    end
  end

  describe "GET #edit" do
    it "renders the edit template" do
      contact = Contact.new valid_attributes
      contact.save
      get :edit, {id: contact.to_param}
      expect(response).to render_template("edit")
    end
  end

  describe "PUT #update" do
    let(:new_attributes) {
      new_attributes = {
        name: "Mary",                            email: valid_attributes[:email],
        birthdate: valid_attributes[:birthdate], phone_number: valid_attributes[:phone_number],
        deleted: valid_attributes[:deleted] }
    }

    it "updates the requested contact" do
      contact = Contact.new valid_attributes
      contact.save
      put :update, {id: contact.to_param, contact: new_attributes}
      expect(Contact.find_by_name("Mary")[0].name).to eq("Mary")
    end

    it "redirects to the Contacts list" do
      contact = Contact.new valid_attributes
      contact.save
      put :update, {id: contact.to_param, contact: new_attributes}
      expect(response).to redirect_to(contacts_path)
    end
  end

  describe "DELETE #destroy" do
    describe "with valid params" do
      before do
        FactoryGirl.create :contact
        FactoryGirl.create :contact
      end

      it "deletes a Contact" do
        contact = Contact.new valid_attributes
        contact.save
        expect {
          delete :destroy, {id: contact.to_param}
        }.to change(Contact, :count).by(-1)
      end

      it "redirects to the Contacts list" do
        contact = Contact.new valid_attributes
        contact.save
        delete :destroy, {id: contact.to_param}
        expect(response).to redirect_to(contacts_url)
      end
    end
  end

end
