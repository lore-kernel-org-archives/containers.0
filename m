From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V5 13/13] Documentation: add a section for /proc/<pid>/ns/
Date: Mon, 13 Oct 2014 15:46:59 +0200
Message-ID: <20141013134659.GL24703@mail.hallyn.com>
References: <cover.1412543112.git.rgb@redhat.com>
	<982503bc4e4c24cbdebd111b27191ed5bee75572.1412543112.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <982503bc4e4c24cbdebd111b27191ed5bee75572.1412543112.git.rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: aviro-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, pmoore-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Richard Guy Briggs (rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org):
> ---

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

(some nitpicking below)

Thanks, Richard.  IMO this patchset is great at the moment.  Now if I
checkpoint a container, migrate it to another machine, and restart it
there, the serial numbers will no longer match, but as the creations are
all logged, userspace can track the changed snum, so I don't believe
that is a problem.  (Pretty sure we've discussed that before, mostly
mentioning it here to think through it myself)

>  Documentation/filesystems/proc.txt |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index ddc531a..c4bfd6f 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -42,6 +42,7 @@ Table of Contents
>    3.6	/proc/<pid>/comm  & /proc/<pid>/task/<tid>/comm
>    3.7   /proc/<pid>/task/<tid>/children - Information about task children
>    3.8   /proc/<pid>/fdinfo/<fd> - Information about opened file
> +  3.9   /proc/<pid>/ns/<ns>{,_snum} - Information about process namespaces
>  
>    4	Configuring procfs
>    4.1	Mount options
> @@ -1744,6 +1745,21 @@ pair provide additional information particular to the objects they represent.
>  	optional and may be omitted if no marks created yet.
>  
>  
> +3.9	/proc/<pid>/ns/<nstype>{,_snum} - Information about process namespaces
> +--------------------------------------------------------------------------
> +These files provides information about the namespaces within which the process

s/provides/provide/

> +is contained.  The files named only with the namespace type <nstype> contain a
> +link that lists the containing namespace' inode number in its proc filesystem.

s/'/'s/

... Maybe add "And which can be used with setns(2)."

> +The files with suffix _snum contain a link that lists the containing
> +namespace' instance serial number, unique per kernel since boot.  The

s/'/'s/

> +namespace types are self-describing.
> +
> +The output format of the inode links is:
> +	<nstype>:[<inode_number>]
> +The output format of the serial number links is:
> +	<nstype>_snum:[<serial_number>]
> +
> +
>  ------------------------------------------------------------------------------
>  Configuring procfs
>  ------------------------------------------------------------------------------
> -- 
> 1.7.1
