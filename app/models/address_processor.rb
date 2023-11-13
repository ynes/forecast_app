# Module to extract the zip code from a US address.
# It makes sure that the scanned zip code is a valid US zip code
# using the ZipCodes gem.

module AddressProcessor
    def self.get_valid_zip_code(address)
        # Extracting the last 5 digits number from the address as zip code.
        zip_code = address.to_s.scan(/\b\d{5}\b/).last

        # ZipCodes.identify returns nil in case the zip code is not a valid US zip code.
        zip_code && ZipCodes.identify(zip_code) ? zip_code : nil
    end
end