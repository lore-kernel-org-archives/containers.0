From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: Constraining the memory used by an unprivilged mount of tmpfs.
Date: Fri, 18 Jan 2013 10:42:15 -0800
Message-ID: <50F99787.3090708@parallels.com>
References: <1358331945-4106-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130116143532.GA4035@sergelap> <50F74EC6.60004@cn.fujitsu.com>
	<20130117171451.GA31219@sergelap> <87fw1zbd03.fsf@xmission.com>
	<20130118042404.GA15079@sergelap> <87vcavys6k.fsf@xmission.com>
	<50F8DEBF.1020701@parallels.com> <87ip6vyqkf.fsf@xmission.com>
	<50F8E73B.7000903@parallels.com> <87ip6vug8p.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ip6vug8p.fsf_-_-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On 01/17/2013 11:01 PM, Eric W. Biederman wrote:
> What are the practical problems with control groups that makes them
> undesirable/hard to use with namespaces?
> 
> What would it take to fix the problems with control groups?
There aren't, from my PoV.
When I run containers, for instance, I basically join all namespaces,
configure all groups, and everything I can.

I do know, however, that not every use case is like that, and those
things tends to be very loosely coupled.

So what I am worried about, is not a valid container usage where you
have your constraints configured. But if I login into a box as a normal
user, and that now allows me to create a userns, and maliciously fire a
big tmpfs from there, cgroups will not gonna be there for me - it's not
a container box, is just something I am trying to break.
