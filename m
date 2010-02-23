From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: Progress of containers at 2.6.32/33?
Date: Tue, 23 Feb 2010 13:32:15 +0100
Message-ID: <4B83CACF.5010701@free.fr>
References: <m1r5oepjye.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1r5oepjye.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> 2.6.32 is likely to be used widely so I expect everyone's out of tree
> patches to be updated.  As a metric to figuring out which things have
> worked and which things have not I would like ask all of those who are
> maintaining out of tree container patches to give some feedback on
> what code they have been able to remove from their patchsets when
> using the latest kernel, and which patches persist.
>
> I have been in some conversations lately that indicate that we have
> some tremendous short comings in the work that has gone on in the
> public tree.  So I am asking now so we can guage where we are at
> as a community.
>   
Do you consider the checkpoint / restart is part of the container progress ?

I am asking that because there are some cases where the container should 
be more virtualized if the CR is to be take into account.
For example, the network devices index is not virtualized in a 
container, this is not a problem without the CR. But with it, we won't 
support any application binding to a device or using a device index.
