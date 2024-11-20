import React from 'react';

const Section = ({ title, description, onDownloadScript, onUploadInfo, onDownloadReport }) => {
    return (
        <div className="card my-3">
            <div className='card-body'>
                <h3 className='card-title'>{title}</h3>
                <p className='card-text'>{description}</p>
                <div className='d-flex gap-2'>
                    <button className='btn btn-primary' onClick={onDownloadScript}>
                        Download Script
                    </button>
                    <button className='btn btn-secondary' onClick={onUploadInfo}>
                        Upload Info
                    </button>
                    <button className='btn btn-success' onClick={onDownloadReport}>
                        Download Report
                    </button>
                </div>
            </div>
        </div>
    )
}

export default Section;