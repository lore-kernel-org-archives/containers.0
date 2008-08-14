From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH][RFC] dirty balancing for cgroups
Date: Thu, 14 Aug 2008 01:38:17 -0700
Message-ID: <6599ad830808140138u15f516fdpace0ba455406efd4__41814.1261594885$1218703246$gmane$org@mail.gmail.com>
References: <20080711141511.515e69a5.kamezawa.hiroyu@jp.fujitsu.com>
	<20080711055926.9AF4F5A03@siro.lan>
	<20080711161349.c5831081.kamezawa.hiroyu@jp.fujitsu.com>
	<1216043344.12595.89.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1216043344.12595.89.camel@twins>
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
To: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Jul 14, 2008 at 6:49 AM, Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org> wrote:
>
> The dirty page limit avoids deadlocks under certain situations, the per
> BDI dirty limit avoids even mode deadlocks by providing isolation
> between BDIs.
>

As well as deadlocks, in the case of cgroups a big advantage of dirty
limits is that it makes it easier to "loan" memory to groups above and
beyond what they have been guaranteed. As long as we limit the
dirty/locked memory for a cgroup to its guarantee, and require any
extra memory to be clean and unlocked, then we can reclaim it in a
hurry if another cgroup (that had been guaranteed that memory) needs
it.

Paul
