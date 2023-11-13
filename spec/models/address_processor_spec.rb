require 'rails_helper'

describe AddressProcessor do
    describe '.get_valid_zip_code' do

        subject { AddressProcessor.get_valid_zip_code(address) }

        context 'valid zip code in address' do

            let(:address) { "1234 Chestnut St, Abc, TA 17603-1234" }

            it 'should return the zip code' do
                expect(subject).to eq("17603")
            end
        end

        context 'address only contains a valid zip code' do
            let(:address) { "21204" }

            it 'should return the zip code' do
                expect(subject).to eq("21204")
            end
        end

        context 'invalid zip code in address' do
            let(:address) { "1234 Chestnut St, Abc, TA 00001" }

            it 'should return nil' do
                expect(subject).to be_nil
            end
        end

        context 'no zip code found' do
            let(:address) { "aaa bbb ccc ddd" }

            it 'should return nil' do
                expect(subject).to be_nil
            end
        end
    end
end