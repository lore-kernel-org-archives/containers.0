From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 7/7] CGroup API: Update cpusets to use cgroup
	structured file API
Date: Mon, 18 Feb 2008 17:55:27 +0800
Message-ID: <47B9560F.3030402__23857.839316088$1203329018$gmane$org@cn.fujitsu.com>
References: <20080215204418.535025000@menage.corp.google.com>	<20080215204821.778088000@menage.corp.google.com>
	<20080216212901.70fe35ce.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080216212901.70fe35ce.pj-sJ/iWh9BUns@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Paul Jackson wrote:
> Ok ... this would (I suspect, just from code reading, no bytes were
> harmed in actual testing of this) have a minor change to how white
> space is handled writing integer flags to cpuset files, and a minor
> inconstency.
> 
>  1) Existing cpuset code lets you set a flag (e.g. cpu_exclusive) by doing:
> 	echo '1 rumplestiltskin' > cpu_exclusive   # same as: echo 1 > cpu_exclusive
>     With this patch, that probably fails, EINVAL.
> 
>  2) With this patch, one can write "1" or "1\n" to cpuset integer files, but one
>     cannot successfully write "1\r\n" or "1 " or "1 \n".  However, for the cpuset
>     control files that take strings, not single integers, one -can- have any mix
>     of trailing white space.
> 
> So far as I know, I have no requirement to write rumplestiltskin to cpuset files ;).
> So I'm content to let the minor change in (1) pass without further comment.
> 
> I'd like to recommend consideration of the following patch, to address the
> minor inconsistency of (2), and to save a few bytes of kernel text space.
> 

For memory controller, we have to do this:
	echo -n 4m > memory.limit_in_bytes
'-n' is necessary. This is another inconsistency..
