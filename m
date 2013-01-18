From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: Constraining the memory used by an unprivilged mount of tmpfs.
Date: Fri, 18 Jan 2013 11:52:29 -0800
Message-ID: <50F9A7FD.6030507@parallels.com>
References: <50F74EC6.60004@cn.fujitsu.com> <20130117171451.GA31219@sergelap>
	<87fw1zbd03.fsf@xmission.com> <20130118042404.GA15079@sergelap>
	<87vcavys6k.fsf@xmission.com> <50F8DEBF.1020701@parallels.com>
	<87ip6vyqkf.fsf@xmission.com> <50F8E73B.7000903@parallels.com>
	<87ip6vug8p.fsf_-_@xmission.com> <50F99787.3090708@parallels.com>
	<20130118194851.GB13983@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130118194851.GB13983@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 01/18/2013 11:48 AM, Serge Hallyn wrote:
> Quoting Glauber Costa (glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org):
>> On 01/17/2013 11:01 PM, Eric W. Biederman wrote:
>>> What are the practical problems with control groups that makes them
>>> undesirable/hard to use with namespaces?
>>>
>>> What would it take to fix the problems with control groups?
>> There aren't, from my PoV.
>> When I run containers, for instance, I basically join all namespaces,
>> configure all groups, and everything I can.
>>
>> I do know, however, that not every use case is like that, and those
>> things tends to be very loosely coupled.
>>
>> So what I am worried about, is not a valid container usage where you
>> have your constraints configured. But if I login into a box as a normal
>> user, and that now allows me to create a userns, and maliciously fire a
>> big tmpfs from there, cgroups will not gonna be there for me - it's not
>> a container box, is just something I am trying to break.
> 
> Hm.  So basically we would, ideally, find a way to make it so that if
> uid 500 creates a new userns and, therein, mounts a tmpfs, then that
> tmpfs gets accounted and limited along with uid 500's RSS?
> 

Dunno.

One option would be to start establishing stronger connections between
cgroups and namespaces in a sane way. And then, we only allow such
mounts when you are actually cgroup backed.

Again, I am not concerned with sane setups in here, but much more with
normal users in normal systems taking advantage of this.
