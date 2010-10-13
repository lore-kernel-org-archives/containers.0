From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] Kconfig : default all the namespaces to 'yes'
Date: Wed, 13 Oct 2010 09:44:30 -0500
Message-ID: <20101013144430.GA20904@hallyn.com>
References: <1286457333-10500-1-git-send-email-daniel.lezcano@free.fr>
	<1286457333-10500-2-git-send-email-daniel.lezcano@free.fr>
	<20101011185757.GJ23839@count0.beaverton.ibm.com>
	<20101012171622.GA16543@hallyn.com> <4CB53F1C.7020709@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4CB53F1C.7020709-GANU6spQydw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Biederman Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> On 10/12/2010 07:16 PM, Serge E. Hallyn wrote:
> >Quoting Matt Helsley (matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> >>On Thu, Oct 07, 2010 at 03:15:33PM +0200, Daniel Lezcano wrote:
> >>>As the different namespaces depend on 'CONFIG_NAMESPACES', it is
> >>>logical to enable all the namespaces when we enable NAMESPACES.
> >>>
> >>>Signed-off-by: Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org>
> >>Subject of the patch email is a little confusing as it's not
> >>quite what happens. I'm mostly OK with it but I'm not sure we
> >>should enable user-ns by default just yet.
> >>
> >>Acked-By: Matt Helsley<matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> >In fact, perhaps we should keep the experimental tag on user namespaces.
> 
> The experimental tag is kept on the user namespace. This one is
> defaulting to yes when the namespaces and experimental are selected.

Oh, sounds good

-serge
