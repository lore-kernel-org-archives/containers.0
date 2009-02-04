From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH] x86_86 support of checkpoint/restart (Re:
	Checkpoint / Restart)
Date: Wed, 04 Feb 2009 08:21:28 -0800
Message-ID: <1233764488.20090.58.camel@nimitz>
References: <EF0F4DD0-96C2-47CF-A247-19002A3BD53B@uni-duesseldorf.de>
	<20090127155947.GB10039@us.ibm.com>
	<090128111035.M0106630@noir.ex.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <090128111035.M0106630-n+Fz6uxiQ6t02ytvwG4l7tBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: m-takahashi-kvZsz0w9TrB8UrSeD/g0lQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Ralph-Gordon.Paul-4bfl1RV3iZDOEhgYWvzSCYQuADTiUCJX@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-01-28 at 11:10 +0900, Masahiko Takahashi wrote:
> I'm now working on porting to x86_64 with help from Nauman Rafique.
> Here is the preliminary patch. If there is someone who is interested
> in x86_64 support, please join.

Do you have anything more recent than this?  I think there are a few
cleanups we can add to get rid of some of the #ifdef mess.  

-- Dave
