From: Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
Subject: Re: [Devel] Re: [PATCH 1/3] Signal semantics for /sbin/init
Date: Mon, 17 Sep 2007 19:24:11 +0400
Message-ID: <20070917152411.GB861@tv-sign.ru>
References: <20070911041030.GA1264@us.ibm.com>
	<20070911111928.GA123@tv-sign.ru> <46E959EB.2070207@fr.ibm.com>
	<20070913165820.GA3465@tv-sign.ru>
	<87myvpo8le.fsf@enki.rimspace.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87myvpo8le.fsf-kiwxAyAbAnkGAYDEi5AF0l6hYfS7NtTn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Pittman <daniel-zvVxMF7wGoXk1uMJSBkQmQ@public.gmane.org>
Cc: Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On 09/14, Daniel Pittman wrote:
>
> Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org> writes:
> > On 09/13, Cedric Le Goater wrote:
> >> Oleg Nesterov wrote:
> 
> [...]
> 
> >> To respect the current init semantic,
> >
> > The current init semantic is broken in many ways ;)
> 
> Yup.  They sure are, but they are pretty set in stone by now. :)
> 
> >> shouldn't we discard any unblockable signal (STOP and KILL) sent by a
> >> process to its pid namespace init process ?  Then, all other signals
> >> should be handled appropriately by the pid namespace init.
> >
> > Yes, I think you are probably right, this should be enough in
> > practice. After all, only root can send the signal to /sbin/init. On
> > my machine, /proc/1/status shows that init doesn't have a handler for
> > non-ignored SIGUNUSED == 31, though.
> >
> > But who knows? The kernel promises some guarantees, it is not good to
> > break them.  Perhaps some strange non-standard environment may suffer.
> 
> In this case "strange non-standard environments" would mean anyone
> running the 'upstart' daemon from recent Ubuntu -- it depends on the
> current kernel semantics.

Just curious, could you tell more? What "current kernel semantics" do you
mean?

Do you mean that the 'upstart' daemon sends the unhandled signal to init?

Oleg.
