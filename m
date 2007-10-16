From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] [PATCH] namespaces: introduce sys_hijack (v4)
Date: Tue, 16 Oct 2007 12:03:17 -0700
Message-ID: <6599ad830710161203h50198ae5o73bfacad32dd8bb6@mail.gmail.com>
References: <20071009200928.GA21846@sergelap.austin.ibm.com>
	<6599ad830710160209w64765f2ao6a1f811b4ea50708@mail.gmail.com>
	<20071016143744.GC30799@sergelap.austin.ibm.com>
	<6599ad830710160932t3769bc29w8a6461274226633d@mail.gmail.com>
	<20071016185737.GA4115@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071016185737.GA4115-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/16/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
> Currently every pid namespace's pid==1 must stick around as long as the
> pid namespace does.  If you kill the pid==1, all processes in the
> container are killed.

What about people who aren't using pid namespaces?

>
> > > Anyway, I can go ahead and add 'int which' to the parameter list now,
> > > and leave the details of how to specify a cgroup for later.  That way at
> > > least the api won't fundamentally change again.
> >
> > Great, thanks.
>
> Since the goal here is to get the API right, do you know how we expect
> to send the cgroup in?  A string?

My thought was to use an fd on an open cgroup directory - that can be
trivially translated into a cgroup.

Paul
