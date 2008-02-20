From: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Subject: Re: [RFC][PATCH 1/7] CGroup API: Add cgroup.api control file
Date: Tue, 19 Feb 2008 23:17:26 -0600
Message-ID: <20080219231726.4bd97520.pj__12719.2658059814$1203484853$gmane$org@sgi.com>
References: <20080215204418.535025000@menage.corp.google.com>
	<20080215204820.734926000@menage.corp.google.com>
	<47B6B5CA.7040201@linux.vnet.ibm.com>
	<6599ad830802160944v6d529570k1ade6df273ca3d0d@mail.gmail.com>
	<47B953A8.9030206@cn.fujitsu.com>
	<20080219155742.0298f25f.pj@sgi.com>
	<6599ad830802191851l66281e67rb49c766c2b1427c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830802191851l66281e67rb49c766c2b1427c9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Paul M wrote:
> I guess it's not essential, I just figured that if we had that
> information, it made sense to make it available to userspace. I guess
> I'm happy with dropping the actual exposed cgroup.api file for now as
> long as we can work towards reducing the number of control files that
> just return strings, and make use of the structured output such as
> read_uint() miore.

I could certainly go along with that ... reducing the proportion of
control files returning untyped strings.

My sense of kernel-user API's is that usually the less said the better.
Identify the essential information that one side requires from the
other via a runtime API, and pass only that.  API's represent a
lifetime commitment, so the less promised the better.

Perhaps my primary concern with these *.api files was that I did not
understand who or what the critical use or user was; who found this
essential, not just nice to have.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.940.382.4214
