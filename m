From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 09/10] Enable multiple instances of devpts
Date: Mon, 29 Sep 2008 16:06:31 +0200
Message-ID: <48E0E0E7.6040204@fr.ibm.com>
References: <20080912174845.GA17350@us.ibm.com>	<20080912175322.GJ17350@us.ibm.com>	<20080924202616.GB31664@us.ibm.com>
	<20080926210347.GB31505@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080926210347.GB31505-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: kyle-hoO6YkzgTuCM0SS3m2neIg@public.gmane.org, bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

[ ... ]

> | >  	/*
> | >  	 * parse_mount_options() restores options to default values
> | > @@ -232,6 +246,8 @@ static int devpts_show_options(struct seq_file *seq, struct vfsmount *vfs)
> | >  	seq_printf(seq, ",mode=%03o", opts->mode);
> | >  #ifdef CONFIG_DEVPTS_MULTIPLE_INSTANCES
> | >  	seq_printf(seq, ",ptmxmode=%03o", opts->ptmxmode);
> | > +	if (opts->newinstance)
> | > +		seq_printf(seq, ",newinstance");
> | 
> | Is actually that something we want to show?  It doesn't seem
> | informative.
> 
> Without this users have no easy way of knowing whether they have a 
> private mount specially if they mounted from command line ?
> 
> Does it mislead or confuse ?

the mount options are already shown in /proc/self/mounts. I don't think you need
a show_options() op.

C.
