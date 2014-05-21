From: Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org>
Subject: Re: [V9fs-developer] Containers over 9p in 3.14
Date: Wed, 21 May 2014 09:07:50 +0100
Message-ID: <537C5ED6.8040502@elastichosts.com>
References: <537B8AFA.4080303@elastichosts.com>
	<20140521065219.GA15962@u-barrelet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140521065219.GA15962@u-barrelet>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dominique Martinet <dominique.martinet-KCE40YydGKI@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, v9fs-developer-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Eric Van Hensbergen <ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 21/05/14 07:52, Dominique Martinet wrote:
> Hi,
> 
> Alin Dobre wrote on Tue, May 20, 2014 at 06:03:54PM +0100:
>> This call used to work fine in 3.13. I haven't tried to bisect and find
>> out the exact patch that introduces the problem, but it's one of "git
>> log --oneline b26d4cd.. fs/9p".
>>
>> I can provide you with any additional information that might be needed.
> 
> For curiosity, I wouldn't mind seeing your exact mount options ? (cache
> if any, access, posixacl if set, etc..)

Nothing fancy, really. I mounted it manually with:
mount -t 9p -o trans=tcp,aname=/some/path,version=9p2000.L 127.0.0.1
/mount/point. I can take a look at /proc/mounts to tell you all the
mount options, including default ones if you need.

> 
> 
> I've got no experience with containers/no setup I could try it with
> right now, but I recall 3.14 broke the xattr_set call - you might want
> to try to revert this one:
> * bdd5c28 9p: fix return value in case in v9fs_fid_xattr_set()
> 
> 
> Philippe Deniel posted about it on this list a while ago but nothing
> that I could see got done to actually fix it, I guess I'll submit
> something today or tomorrow with proper fix (e.g. keep negative value if
> there's an error to report, but 0 on success)
> 
> 
> I'll have a harder look if this isn't enough.
> 

I noticed you sent a patch, I will try that and come back with the result.

Thanks a lot for the support, Dominique!

Cheers,
Alin.
