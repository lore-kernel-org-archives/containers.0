From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [NETNS45][PATCH 1/1] Fix network namespace unshare support.
Date: Sun, 16 Sep 2007 20:55:38 -0600
Message-ID: <m1r6kyt2z9.fsf@ebiederm.dsl.xmission.com>
References: <20070914162637.429733612@frecb000701.frec.bull.fr>
	<20070914162735.674439633@frecb000701.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070914162735.674439633-okVqAf2pJUEelBkcLfQrlDWMkbuR3peG@public.gmane.org> (benjamin
	thery's message of "Fri, 14 Sep 2007 18:26:38 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: benjamin.thery-6ktuUTfB/bM@public.gmane.org
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

benjamin.thery-6ktuUTfB/bM@public.gmane.org writes:

> Add CLONE_NEWNET flag in sys_unshare() test.
>
> This patch should be merged with commit: 
> "net: Add network namespace clone & unshare support."
>
> Signed-off-by: Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>

Thanks you guys are really doing a good job catching when I slip up.

Eric
