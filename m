From: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] cgroup : add clone_children control file
Date: Tue, 7 Sep 2010 14:22:50 -0700
Message-ID: <AANLkTik+wrNXZtcD_0OcGQUtcZbu7SVNUUaTKHqTBf8m@mail.gmail.com>
References: <1283585466-30265-1-git-send-email-daniel.lezcano@free.fr>
	<AANLkTi=hM66-F-U2-ZoiDgksh51hq3MLb5aSLmwsShwi@mail.gmail.com>
	<4C869F48.9050603@free.fr>
	<AANLkTi=zsT4=YZgpu5x9xtgskoTCjgTq+Vt6wh-8QtB=@mail.gmail.com>
	<4C86AAE1.2030608@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4C86AAE1.2030608-GANU6spQydw@public.gmane.org>
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
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Sep 7, 2010 at 2:13 PM, Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>
> The clone_children option behaves like the release-agent mount option no ?

Not quite, since it can be controlled on a per-cgroup basis.

> We can mount with a specific release agent and change it at runtime. IMHO it
> would be better to give a chance to the administrator to set its system with
> the mount option instead of force him to write post mount scripts. An
> alternative would be to set this cgroup option *only* via the mount option,
> but I am not sure it is good as it may be an unresolvable constraint for a
> system wanting to use the cgroups with and without this option (same kind of
> constraint we have with the ns_cgroup).
>
> I am favorable to keep the mount option and the ability to change it for
> another cgroup.

OK, lets mostly keep the current patch, but lose the flag stored at
mount-time and just report the mount option based on the current value
of the root cgroup's flag.

Paul
