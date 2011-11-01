From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Mon, 31 Oct 2011 20:19:44 -0700
Message-ID: <m1r51swmun.fsf@fess.ebiederm.org>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111101021230.GE15906-+4JsuViRYHWM0MU9lROt9PpTrGXM5HoexJJUWDj/nkeELgA04lAiVw@public.gmane.org>
	(Toerless Eckert's message of "Tue, 1 Nov 2011 03:12:30 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org> writes:

> I am trying to understand if (and if so how) i can use LXC (or any
> other comparable lightweightc container option) to effectively
> run applications on a linux system with two separate IP interfaces
> as if they each had only access to a single IP interface.
>
> Eg:
>     eth0 with address and default-router learned by DHCP
>     eg: address 10.1.1.2/24, default-router 10.1.1.254
>     DNS prefix and DNS domain name for ether0 of course also learned by DHCP.
>
>     eth1 with address and default-router learned by DHCP
>     eg: address 10.2.1.a/242, default-router 10.2.1.254
>     DNS prefix and DNS domain name for ether0 of course also learned by DHCP.
>
>     (no need for overlapping addresses).

That sounds like L2 level isolation.

ip link set eth1 netns XXXX.

Will let move a network device to a choose network namespace.

That is the easy trivial case.  Most people don't have the multiple
physical interfaces so tricky things have to happen.

Does that sound like what you are looking for?

Eric
