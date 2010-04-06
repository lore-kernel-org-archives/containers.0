From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: lxc, conntrack and routecache
Date: Tue, 06 Apr 2010 08:05:42 -0700
Message-ID: <m1iq84aaex.fsf__12883.2782422707$1270566389$gmane$org@fess.ebiederm.org>
References: <20100404090757.6f1ac500@catlap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100404090757.6f1ac500@catlap> (Marek Kierdelewicz's message of
	"Sun\, 4 Apr 2010 09\:07\:57 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Marek Kierdelewicz <marek-93dTLfYBX/9mR6Xm/wNWPw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Marek Kierdelewicz <marek-93dTLfYBX/9mR6Xm/wNWPw@public.gmane.org> writes:

> Hi,
>
> I'm evaluating lxc for use in virtualized routing/bridgeing
> infrastructure. I'm particulary interested in conntrack and routecache
> behaviour. I had run some tests and established that routecache and
> conntrack is not shared between containers and base system. Are data
> structures for routeche and conntrack in kernel shared (with each entry
> marked with namespace id) or new data structure is created for each new
> container?

What does it matter?

Eric
