From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] CFS CGroup: Code cleanup
Date: Tue, 23 Oct 2007 00:42:33 -0700
Message-ID: <6599ad830710230042j1732149bw4cb8a4632a8c77bf__15845.4246273779$1193125447$gmane$org@mail.gmail.com>
References: <471D4510.9030200@google.com>
	<20071023024654.GD3324@linux.vnet.ibm.com>
	<6599ad830710222316i353a25a7ha3d7f179da8cb3c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710222316i353a25a7ha3d7f179da8cb3c7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
To: vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/22/07, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> On 10/22/07, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> >
> > Minor nit: From pov of making this patch series git bisect safe, shouldn't we
> > be registering a write_uint() handler in this patch as well?
> >
>
> Yes, we should. Sigh. I originally had the cleanup and the new
> reporting interface in the same patch, and decided to split them apart
> into a cleanup patch and a new feature patch, but clearly goofed. I'll
> resend tomorrow with the write_uint registration in the right place.

OK, this wasn't a patch goof - the original patch in my tree does have
the addition of write_uint in the cftype definition. I guess the last
hunk got lost as I transferred it to the email.

Paul
