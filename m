From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [Devel] Re: [RFC][patch 3/3] activate filtering for the bind
Date: Mon, 10 Sep 2007 11:15:19 -0700
Message-ID: <6599ad830709101115l3894d8fek4ca415d7a62012f5@mail.gmail.com>
References: <20070904170022.964253374@dyn-9-101-17-26.toulouse-stg.fr.ibm.com>
	<20070904171528.704108193@dyn-9-101-17-26.toulouse-stg.fr.ibm.com>
	<20070905161848.GN1403@sergelap.austin.ibm.com>
	<46DEDBA1.9010706@meiosys.com>
	<20070910132330.GB9565@sergelap.austin.ibm.com>
	<46E54C11.1050403@fr.ibm.com>
	<20070910154630.GA3905@sergelap.austin.ibm.com>
	<6599ad830709101049g5ea45749k66e362326264b4b0@mail.gmail.com>
	<20070910181131.GB31638@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070910181131.GB31638-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
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

On 9/10/07, Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
> Perhaps the biggest upside of this approach is that it's providing
> network functionality in a way that should be much more familiar to
> network folks.  As opposed to using an lsm with a new vfs interface.

Right - one of the things that I promised at the kernel summit was
that we'd be very careful about introducing random new userspace APIs
as part of control files. Reusing existing APIs where practical is way
nicer.

>
> Is anyone working on this implementation, for comparison to the lsm
> patch?

Eric may be; if not then it's something I'd be interested in doing but
probably won't have time for, for a couple of weeks at least. So if
someone else wanted to play with it in the meantime that would be
great.

Paul
