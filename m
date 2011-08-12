From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH v2 0/4] Per-container dcache size limitation
Date: Fri, 12 Aug 2011 07:52:41 -0300
Message-ID: <4E4505F9.1040609__25670.2325343669$1313146454$gmane$org@parallels.com>
References: <1312504544-1108-1-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1312504544-1108-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Rik van Riel <riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Nick Piggin <npiggin-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, David Chinner <david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 08/04/2011 09:35 PM, Glauber Costa wrote:
> Hi,
>
> Since v1, there is not too much new here.
> I'm incorporating David's suggestion of calling the sb
> shrinker, which will, in effect, prune the icache and
> other sb related objects as well.
>
> I am also keeping the mount based interface, since I
> still believe it is the way to go. But I'm obviously
> still open for suggestions. Some small corrections
> were also made to it since v1. Specifically, bind
> mounts are not allowed to alter the original sb dcache
> size.
>
> Glauber Costa (4):
>    factor out single-shrinker code
>    Keep nr_dentry per super block
>    limit nr_dentries per superblock
>    parse options in the vfs level
>
>   fs/dcache.c              |   44 +++++++++++-
>   fs/namespace.c           |  105 ++++++++++++++++++++++++++
>   fs/super.c               |   16 ++++-
>   include/linux/dcache.h   |    4 +
>   include/linux/fs.h       |    3 +
>   include/linux/shrinker.h |    6 ++
>   mm/vmscan.c              |  185 ++++++++++++++++++++++++----------------------
>   7 files changed, 274 insertions(+), 89 deletions(-)
>
People,

Any comments on this? I think I addressed all the comments previously
made, and if there are no further requests, I think this is ready for
getting in. In case there are issues, please let me know so I can 
address them.
