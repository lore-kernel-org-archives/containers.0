From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: Interaction user namespace, /proc/1 ownership & cap_set
Date: Fri, 12 Jul 2013 11:04:20 +0100
Message-ID: <20130712100420.GD25475@redhat.com>
References: <20130701161625.GQ15954@redhat.com>
	<51D261D3.3030002@cn.fujitsu.com> <87wqp9uz9a.fsf@xmission.com>
	<51D295C5.1080003@nod.at> <20130702092554.GD2524@redhat.com>
	<87ehbhthbl.fsf@xmission.com> <51D2A649.9030102@cn.fujitsu.com>
	<8761wsudgk.fsf@xmission.com> <20130702164514.GB2524@redhat.com>
	<87k3l8sx6l.fsf@xmission.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87k3l8sx6l.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Jul 02, 2013 at 10:12:34AM -0700, Eric W. Biederman wrote:
> "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Ah, yes, that would explain it. My demo is removing the SYS_MODULE
> > capability, and then exec'ing the shell binary. Since we are uid==0,
> > and prctl(PR_CAPBSET_DROP) is not available inside the user namespace,
> > the rules for capabilities vs execve() call will cause the shell
> > binary to regain SYS_MODULE capability bit.
> >
> > So the problem I'm seeing in libvirt is all a result of the fact
> > that we can't use PR_CAPBSET_DROP inside the user namespace. Given
> > that there's no point trying to drop any capabilities inside the
> > user namespace.
> >
> > The only slight problem here is that we want to drop CAP_MKNOD so
> > that systemd can detect that it shouldn't attempt to run any units
> > which would rely on mknod.
> 
> I just looked at that and I don't see a justification for the
> restriciton.
> 
> Could you try the patch below and see if it fixes things for you?
> 
> Eric
> 
> 
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> Date: Tue, 2 Jul 2013 10:04:54 -0700
> Subject: [PATCH] userns: Allow PR_CAPBSET_DROP in a user namespace.
> 
> As the capabilites and capability bounding set are per user namespace
> properties it is safe to allow changing them with just CAP_SETPCAP
> permission in the user namespace.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  security/commoncap.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/security/commoncap.c b/security/commoncap.c
> index 4d787e6..fd9b08f 100644
> --- a/security/commoncap.c
> +++ b/security/commoncap.c
> @@ -843,7 +843,7 @@ int cap_task_setnice(struct task_struct *p, int nice)
>   */
>  static long cap_prctl_drop(struct cred *new, unsigned long cap)
>  {
> -	if (!capable(CAP_SETPCAP))
> +	if (!ns_capable(current_user_ns(), CAP_SETPCAP))
>  		return -EPERM;
>  	if (!cap_valid(cap))
>  		return -EINVAL;

Yes, that works in my testing with libvirt. Feel free to add

  Tested-by: Daniel P. Berrange <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
