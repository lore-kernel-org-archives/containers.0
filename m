From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup attach/fork hooks consistency with the ns_cgroup
Date: Thu, 18 Jun 2009 08:45:27 -0500
Message-ID: <20090618134527.GA3186@us.ibm.com>
References: <4A390D5D.5040702@free.fr> <20090617212614.GA26781@us.ibm.com>
	<6599ad830906171821v3c97f176y65bd4b7fa9a405e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830906171821v3c97f176y65bd4b7fa9a405e9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
> On Wed, Jun 17, 2009 at 2:26 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > The ns cgroup is really only good for preventing root in a container
> > from escaping its cgroup-imposed limits.  The same can be done today
> > using smack or selinux, and eventually will be possible using user
> > namespaces.  Would anyone object to removing ns_cgroup?
> 
> Sounds reasonable to me. It feels to me that there ought to be some
> good way to integrate namespaces and cgroups, but I'm not quite sure
> exactly how, and ns_cgroup sort of hovers in the "toy" category rather
> than something very useful.

So the question becomes: does the presence of the ns cgroup constitute
an API?  Can we just yank it out?

Daniel, AFAIK liblxc is the only thing that actually uses it.  Do
you mind manually moving the container init into a new cgroup?

-serge
