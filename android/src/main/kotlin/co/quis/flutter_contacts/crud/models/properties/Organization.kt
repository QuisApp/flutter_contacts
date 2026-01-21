package co.quis.flutter_contacts.crud.models.properties

import android.content.ContentProviderOperation
import android.database.Cursor
import co.quis.flutter_contacts.common.CursorHelpers.getStringOrNull
import co.quis.flutter_contacts.crud.models.JsonHelpers
import java.util.Objects
import android.provider.ContactsContract.CommonDataKinds.Organization as OrganizationData

data class Organization(
    val name: String? = null,
    val jobTitle: String? = null,
    val departmentName: String? = null,
    val phoneticName: String? = null,
    val jobDescription: String? = null,
    val symbol: String? = null,
    val officeLocation: String? = null,
    val metadata: PropertyMetadata? = null,
) {
    companion object {
        fun fromJson(json: Map<String, Any?>): Organization =
            Organization(
                name = json["name"] as? String,
                jobTitle = json["jobTitle"] as? String,
                departmentName = json["departmentName"] as? String,
                phoneticName = json["phoneticName"] as? String,
                jobDescription = json["jobDescription"] as? String,
                symbol = json["symbol"] as? String,
                officeLocation = json["officeLocation"] as? String,
                metadata = JsonHelpers.decodeOptionalObject(json, "metadata", PropertyMetadata::fromJson),
            )

        fun fromCursor(cursor: Cursor): Organization? {
            val org =
                Organization(
                    name = cursor.getStringOrNull(OrganizationData.COMPANY),
                    jobTitle = cursor.getStringOrNull(OrganizationData.TITLE),
                    departmentName = cursor.getStringOrNull(OrganizationData.DEPARTMENT),
                    phoneticName = cursor.getStringOrNull(OrganizationData.PHONETIC_NAME),
                    jobDescription =
                        cursor.getStringOrNull(OrganizationData.JOB_DESCRIPTION),
                    symbol = cursor.getStringOrNull(OrganizationData.SYMBOL),
                    officeLocation =
                        cursor.getStringOrNull(OrganizationData.OFFICE_LOCATION),
                    metadata = PropertyHelpers.extractMetadata(cursor),
                )
            return if (org.name != null ||
                org.jobTitle != null ||
                org.departmentName != null ||
                org.phoneticName != null ||
                org.jobDescription != null ||
                org.symbol != null ||
                org.officeLocation != null
            ) {
                org
            } else {
                null
            }
        }
    }

    fun toJson(): Map<String, Any?> {
        val result = mutableMapOf<String, Any?>()
        JsonHelpers.encodeOptional(result, "name", name)
        JsonHelpers.encodeOptional(result, "jobTitle", jobTitle)
        JsonHelpers.encodeOptional(result, "departmentName", departmentName)
        JsonHelpers.encodeOptional(result, "phoneticName", phoneticName)
        JsonHelpers.encodeOptional(result, "jobDescription", jobDescription)
        JsonHelpers.encodeOptional(result, "symbol", symbol)
        JsonHelpers.encodeOptional(result, "officeLocation", officeLocation)
        JsonHelpers.encodeOptionalObject(result, "metadata", metadata) { it.toJson() }
        return result
    }

    private fun isNotEmpty(value: String?) = !value.isNullOrBlank()

    fun toInsertOperation(
        rawContactId: Long? = null,
        rawContactIndex: Int = 0,
        addYield: Boolean = false,
    ): ContentProviderOperation =
        PropertyHelpers.buildInsertOperation(
            rawContactId,
            rawContactIndex,
            OrganizationData.CONTENT_ITEM_TYPE,
            addYield,
        ) {
            if (isNotEmpty(name)) withValue(OrganizationData.COMPANY, name?.trim())
            if (isNotEmpty(jobTitle)) withValue(OrganizationData.TITLE, jobTitle?.trim())
            if (isNotEmpty(departmentName)) {
                withValue(OrganizationData.DEPARTMENT, departmentName?.trim())
            }
            if (isNotEmpty(jobDescription)) {
                withValue(OrganizationData.JOB_DESCRIPTION, jobDescription?.trim())
            }
            if (isNotEmpty(symbol)) withValue(OrganizationData.SYMBOL, symbol?.trim())
            if (isNotEmpty(phoneticName)) {
                withValue(OrganizationData.PHONETIC_NAME, phoneticName?.trim())
            }
            if (isNotEmpty(officeLocation)) {
                withValue(OrganizationData.OFFICE_LOCATION, officeLocation?.trim())
            }
        }

    fun toUpdateOperation(): ContentProviderOperation =
        PropertyHelpers.buildUpdateOperation(
            PropertyHelpers.requireDataId(metadata, "organization"),
        ) {
            if (isNotEmpty(name)) withValue(OrganizationData.COMPANY, name?.trim())
            if (isNotEmpty(jobTitle)) withValue(OrganizationData.TITLE, jobTitle?.trim())
            if (isNotEmpty(departmentName)) {
                withValue(OrganizationData.DEPARTMENT, departmentName?.trim())
            }
            if (isNotEmpty(jobDescription)) {
                withValue(OrganizationData.JOB_DESCRIPTION, jobDescription?.trim())
            }
            if (isNotEmpty(symbol)) withValue(OrganizationData.SYMBOL, symbol?.trim())
            if (isNotEmpty(phoneticName)) {
                withValue(OrganizationData.PHONETIC_NAME, phoneticName?.trim())
            }
            if (isNotEmpty(officeLocation)) {
                withValue(OrganizationData.OFFICE_LOCATION, officeLocation?.trim())
            }
        }

    fun toDeleteOperation(): ContentProviderOperation =
        PropertyHelpers.buildDeleteOperation(
            PropertyHelpers.requireDataId(metadata, "organization"),
        )

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is Organization) return false
        return name == other.name &&
            jobTitle == other.jobTitle &&
            departmentName == other.departmentName &&
            phoneticName == other.phoneticName &&
            jobDescription == other.jobDescription &&
            symbol == other.symbol &&
            officeLocation == other.officeLocation
    }

    override fun hashCode() =
        Objects.hash(
            name,
            jobTitle,
            departmentName,
            phoneticName,
            jobDescription,
            symbol,
            officeLocation,
        )
}
