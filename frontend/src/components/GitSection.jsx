import Section from "../prototypeComponents/Section"

const GitSection = () => {
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
            title="Git"
            description="git desc"
            onDownloadScript={handleDownloadScript}
            onUploadInfo={handleUploadInfo}
            onDownloadReport={handleDownloadReport}
        />
    );
}

export default GitSection;