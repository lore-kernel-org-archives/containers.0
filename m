From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [RFC] [PATCH 2/2] namespace enter: introduce
	sys_hijack (v3)
Date: Mon, 10 Sep 2007 14:17:43 -0500
Message-ID: <20070910191743.GB18654@sergelap.austin.ibm.com>
References: <20070829200420.GA4870@sergelap.austin.ibm.com>
	<20070829200515.GC4870@sergelap.austin.ibm.com>
	<6599ad830709030102w6b5084d4w4a8a9a654e421527@mail.gmail.com>
	<20070904125019.GA22410@sergelap.austin.ibm.com>
	<1188932778.28903.361.camel@localhost>
	<20070904193256.GA494@sergelap.austin.ibm.com>
	<6599ad830709050915r5c4fb424ha2081c7d8596aac6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830709050915r5c4fb424ha2081c7d8596aac6-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On 9/4/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > We could of course have the ns_container subsystem do that.  The
> > ns_container generally stick around until the admin does a manual rm on
> > its directory, so this way we could keep the nsproxy around.
> 
> So how about taking sys_hijack() even further and integrate it with
> control groups too? So when you do sys_hijack() (or maybe an
> alternative name would be sys_fork_in()?) you create a task that
> inherits all the control groups of the target task, as well as the
> namespaces.
> 
> Paul

Sorry don't know why i haven't replied to this.

Good point.  I see container_fork(p) takes the container from current.
I can change that to container_fork(src, dest) in my next posting.

Is there any reason why we wouldn't want to do that?  For instance a
container admin could impose some restrictions which would keep the host
admin from doing something through sys_hijack()?  (Not sure that's a big
worry since the restrictions would apply to the container admin as well)

thanks,
-serge
