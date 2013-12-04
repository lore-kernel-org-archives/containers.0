From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 10/12] cgroup: attach cgroup_open_file to all cgroup files
Date: Wed, 4 Dec 2013 08:04:50 -0500
Message-ID: <20131204130450.GE3158@htj.dyndns.org>
References: <1385595759-17656-1-git-send-email-tj@kernel.org>
	<1385595759-17656-11-git-send-email-tj@kernel.org>
	<529EC5F4.10708@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <529EC5F4.10708-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Dec 04, 2013 at 02:04:36PM +0800, Li Zefan wrote:
> > @@ -2353,10 +2338,18 @@ static int cgroup_file_open(struct inode *inode, struct file *file)
> >  	WARN_ON_ONCE(cfe->css && cfe->css != css);
> >  	cfe->css = css;
> >  
> > -	if (cft->open)
> > +	if (cft->open) {
> >  		err = cft->open(inode, file);
> > -	else
> > -		err = single_open(file, cgroup_seqfile_show, cfe);
> > +	} else {
> > +		err = single_open_size(file, cgroup_seqfile_show, cfe,
> > +				       sizeof(struct cgroup_open_file));
> 
> This is wrong.
> 
> I guess you wanted to use single_open_private(), which doesn't exist.

Yeah, right, I got completely confused about what single_open_size()
was doing.  Hah, so, I guess I'll just introduce the single callbacks
here using seq_open_private().  More on this in the next patch.

Thanks.

-- 
tejun
