From: richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] new cgroup controller "fork"
Date: Thu, 3 Nov 2011 18:31:23 +0100
Message-ID: <CAFLxGvzRG_zgG_4ym9CkTOr3kNzNb6zb553kgdy3jCeJSxAP9Q@mail.gmail.com>
References: <20111103162238.27609.11515.stgit@rabbit.intern.cm-ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111103162238.27609.11515.stgit-Rjmu19FXx3rR8JxBgnUBv+rzNCUFrscg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, max-hDT0AjmEH7RAfugRpC6u6w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, Nov 3, 2011 at 5:22 PM, Max Kellermann <mk-xMchvyqCc6DQT0dZR+AlfA@public.gmane.org> wrote:
> +struct cgroup_fork {
> + =A0 =A0 =A0 struct cgroup_subsys_state css;
> +
> + =A0 =A0 =A0 /** protect the "remaining" attribute */
> + =A0 =A0 =A0 spinlock_t lock;
> +
> + =A0 =A0 =A0 /**
> + =A0 =A0 =A0 =A0* The remaining number of forks allowed. =A0-1 is the ma=
gic
> + =A0 =A0 =A0 =A0* value for "unlimited".
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 int remaining;
> +};

Wouldn't an atomic_t also do it?

-- =

Thanks,
//richard
