import Section from "../prototypeComponents/Section"

const VMSection = () => {
    const handleDownloadScript = () => {
        console.log('handle download script');
    };
    const handleUploadInfo = () => {
        console.log('handle upload info');
    };
    const handleDownloadReport = () => {
        console.log('handle download report');
    };
    return (
        <Section
            title="VM"
            description="vm desc"
            onDownloadScript={handleDownloadScript}
            onUploadInfo={handleUploadInfo}
            onDownloadReport={handleDownloadReport}
        />
    );
}

export default VMSection;