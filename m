From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch 1/4][resend] fuse-procfs: proxy proc files
Date: Thu, 10 Sep 2009 21:57:07 -0500
Message-ID: <20090911025707.GA24005@us.ibm.com>
References: <20090904162556.407556958@mai-009101017029.toulouse-stg.fr.ibm.com>
	<20090904165149.491603361@mai-009101017029.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090904165149.491603361-+lpkiSBCrgqwGcPS5fe+fxcU4LlsiAD9x8DZ0lRKBDr1ENwx4SLHqw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> This patch makes possible to mount the fuse-procfs on top of /proc
> and display the content of /proc via fuse.
> 
> Signed-off-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

Thanks, Daniel.  This is neat.  How were you thinking of
configuring this?  A config file read at mount?

Actually one question I have is:

> +static int procfs_read(const char *path, char *buf, size_t size,
> +		      off_t offset, struct fuse_file_info *fi)
> +{
> +	int ret;
> +	struct procfs_file *pfile = (typeof(pfile))fi->fh;;
> +
> +	switch (pfile->type) {
> +
> +	case PROCFS_PROXY:
> +		ret = read(pfile->file.proxy.fd, buf, size);

Are you supposed to do something with the offset?  I don't see
any seek method in fuse_operations, does fuse keep the fp
internally and send it along as offset to read?

> +		if (ret < 0)
> +			return -errno;
> +		break;
> +	}
> +
> +	return ret;
> +}

-serge
