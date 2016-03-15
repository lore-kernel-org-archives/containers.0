From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH] devpts: Make ptmx be owned by the userns owner instead of
	userns-local 0
Date: Tue, 15 Mar 2016 11:21:23 -0700
Message-ID: <CALCETrVe+2mb9xEPO_Vk8poX=dR2qp4OM=23JOspSibKZK3GSg@mail.gmail.com>
References: <fd99f5e7144be5de87c88e069cd5edb36136eefd.1457931898.git.luto@kernel.org>
	<20160314083501.GB23225@ubuntumail>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20160314083501.GB23225@ubuntumail>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: gnome-os-list-rDKQcyrBJuzYtjvyW6yDsg@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, mclasen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mar 14, 2016 1:35 AM, "Serge Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
>
> Quoting Andy Lutomirski (luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> > We used to have ptmx be owned by the inner uid and gid 0.  Change
> > this: if the owner and group are both mapped but are not both 0,
> > then use the owner instead.
> >
> > For container-style namespaces (LXC, etc), this should have no
> > effect -- UID 0 is will either be the owner or will be unmapped.
>
> This doesn't seem right - it's often the case that the owner is mapped
> in as non-0 uid, safe or not.  The actual namespace root uid should be
> the owner (so long as it exists).
>
> Why not reverse the cases?  If 0 is not mapped, then check whether the
> current_user_ns()->owner is mapped?

Good point, and less chance of breakage that way as well.

--Andy
