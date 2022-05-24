addpath(genpath('/home/inb/lconcha/fmrilab_software/tools/matlab/niak-0.6.4.1/'))

% cargar archivo 4D
fname = '/misc/sherrington/alfonso/fmri_analysis/analisis_epilepsia/imagenes/incluidos_rs/sub-x_bandpassed_demeaned_filtered_antswarp_FWHM6.nii.gz';
[hdrfmri,rsfmri] = niak_read_nifti(fname);

% cargar mascara
fname = '/misc/sherrington/alfonso/fmri_analysis/analisis_epilepsia/imagenes/sub_mask/sub-x_mask.nii.gz';
[hdrmask,mask] = niak_read_nifti(fname);

% cargar seed
fname = '/misc/sherrington/alfonso/fmri_analysis/rois/esf/GFMIsphere5_std_bin.nii.gz';
[hdrseed,seedmask] = niak_read_nifti(fname);

% extraer time series del seed
ntimepoints = size(rsfmri,4);
seed = zeros(ntimepoints,1);
for t = 1 : ntimepoints
   this_frame = rsfmri(:,:,:,t);
   seed(t) = mean(this_frame(seedmask>0));
end


rmap = zeros(size(mask));
pmap = zeros(size(mask));
nanmap = zeros(size(mask));
for r = 1 : size(rsfmri,1)
   for c = 1 : size(rsfmri,2)
      for s = 1 : size(rsfmri,3)
          if mask(r,c,s) == 1
              this_ts = squeeze(rsfmri(r,c,s,:));
              [rho,p] = corr(this_ts,seed);
              rmap(r,c,s) = rho;
              pmap(r,c,s) = p;
              if isnan(r) |c isnan(p)
                 fprintf(1,'%s %d %d %d\n','aqui hay un NaN',r,c,s) 
                 nanmap(r,c,s) = 1;
                 if sum(this_ts) == 0
                    rmap(r,c,s) = 0;
                    pmap(r,c,s) = 1;
                    continue 
                 else
                   fprintf(1,'%s %d %d %d\n','Super raro, aqui hay un NaN',r,c,s) 

                 end
              end
          else
             rmap(r,c,s) = 0;
             pmap(r,c,s) = 1;
          end
      end
   end
end

index = find(pmap>0.05);
rxp = rmap;
rxp(index) = 0;


hdrrmap = hdrmask;
hdrrmap.file_name = 'sub-x_GFMI_rmap.nii.gz';
niak_write_nifti(hdrrmap,rmap);

hdrpmap = hdrmask;
hdrpmap.file_name = 'sub-x_GFMI_pmap.nii.gz';
niak_write_nifti(hdrpmap,pmap);

hdrrxpmap = hdrmask;
hdrrxpmap.file_name = 'sub-x_GFMI_rxpmap.nii.gz';
niak_write_nifti(hdrrxpmap,rxp);

hdrnanmap = hdrmask;
hdrnanmap.file_name = 'sub-x_GFMI_nanmap.nii.gz';
niak_write_nifti(hdrnanmap,nanmap);

