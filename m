From: Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org>
Subject: Re: Loadable cgroup subsystems
Date: Tue, 08 Apr 2008 15:10:29 +0530
Message-ID: <1207647629.7798.40.camel@nikanth-laptop.blr.novell.com>
References: <1207633175.7798.5.camel@nikanth-laptop.blr.novell.com>
	<47FB54CC.BANGALORE.BLR.100.174746A.1.1545B.1@1:7.BANGALORE.BLR.100.0.1.0.1@16>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47FB54CC.BANGALORE.BLR.100.174746A.1.1545B.1@1:7.BANGALORE.BLR.100.0.1.0.1@16>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Vasily Tarasov <vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, 2008-04-07 at 22:43 -0700, Paul Menage wrote:
> On Mon, Apr 7, 2008 at 10:39 PM, Nikanth Karthikesan <knikanth-l3A5Bk7waGM@public.gmane.org> wrote:
> >
> >  Why not provide a interface to add subsystems at run-time instead?
> >  Are there any reason for not letting a subsystem to be implemented as a
> >  loadable module? IOW make cgroups usable by modules?
> >
> 
> Having all the subsystems declared at compile time makes a lot of
> things (number of subsystems, size of css_set, etc) statically known,
> which makes the code clearer and more importantly eliminates a bunch
> of locking/synchronization overhead.
> 

true

> It would be possible to make cgroups support dynamically-loaded
> subsystems, and in fact, some of the earliest cgroups patches did
> support this, for a predefined max number of subsystems. But it would
> introduce more complexity and overhead.
> 
> I'd rather not add support for this without a strong case of a
> subsystem that really needs to be dynamically loaded.

There were some band-width control patches based on cfq + cgroups, which
I guess will mandate cfq to be built-in?

Thanks
Nikanth Karthikesan
