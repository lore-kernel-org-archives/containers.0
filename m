From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: Loadable cgroup subsystems
Date: Tue, 8 Apr 2008 02:41:16 -0700
Message-ID: <6599ad830804080241u68d68e2bo8739f907306571bd@mail.gmail.com>
References: <1207633175.7798.5.camel@nikanth-laptop.blr.novell.com>
	<1207647629.7798.40.camel@nikanth-laptop.blr.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1207647629.7798.40.camel-6V/ZMFSzLJEY2a5ovjdQkMfQ/htzPhTPEvhb3Hwu1Ks@public.gmane.org>
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
To: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Cc: Vasily Tarasov <vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 8, 2008 at 2:40 AM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
>  >
>  > I'd rather not add support for this without a strong case of a
>  > subsystem that really needs to be dynamically loaded.
>
>  There were some band-width control patches based on cfq + cgroups, which
>  I guess will mandate cfq to be built-in?
>

Yes, or else have built-in stubs for the cgroup subsystem that load
cfq and the code that uses cfq the first time someone tries to mount
that subsystem.

Actually, it probably wouldn't be too hard to have cgroups do that
automatically - support the concept of a stub cgroup that was known
about at compile time but wasn't active until its first bind, and have
cgroups dynamically load the relevant modules when the user tried to
mount it.

Dynamically loading subsystems that aren't even known about at compile
time would be probably a bit uglier.

Paul
