From: Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 05/10] Introduce function to dump process
Date: Fri, 24 Oct 2008 08:40:16 +0400
Message-ID: <200810240840.17531.major@openvz.org>
References: <1224285098-573-1-git-send-email-major@openvz.org>
	<1224285098-573-6-git-send-email-major@openvz.org>
	<20081020174801.GB29092@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081020174801.GB29092-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Monday 20 October 2008 21:48 Serge E. Hallyn wrote:
> Quoting Andrey Mirkin (major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org):
> > +	t->cpt_uid = tsk->uid;
> > +	t->cpt_euid = tsk->euid;
> > +	t->cpt_suid = tsk->suid;
> > +	t->cpt_fsuid = tsk->fsuid;
> > +	t->cpt_gid = tsk->gid;
> > +	t->cpt_egid = tsk->egid;
> > +	t->cpt_sgid = tsk->sgid;
> > +	t->cpt_fsgid = tsk->fsgid;
>
> I don't see where any of these are restored.  (Obviously, I wanted
> to think about how you're verifying the restarter's authorization
> to do so)

Well, right now I don't use them during restore to simplify restart procedure 
and make it more clear for reviewers. In OpenVZ we are doing all restart 
procedure with root's privileges and relying on fact that all such IDs will 
be the same during restart (as we are restarting a container and its file 
system will be the same during restart).

Andrey
