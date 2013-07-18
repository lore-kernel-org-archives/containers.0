From: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Subject: Re: Single process controlling all cgroups sounds like looking in
	right direction but wrong solution.
Date: Thu, 18 Jul 2013 04:38:25 -0500
Message-ID: <1374140305.3719.16__47451.0254025974$1374185515$gmane$org@driftwood>
References: <20130715123216.GA5663@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="Flowed"; DelSp="Yes"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130715123216.GA5663@sergelap> (from serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org
	on Mon Jul 15 07:32:16 2013)
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Peter Dolding <oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 07/15/2013 07:32:16 AM, Serge Hallyn wrote:
> Quoting Peter Dolding (oiaohm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> > I followed the Maintainers File.   
> https://www.kernel.org/doc/linux/MAINTAINERS
> > CONTROL GROUPS (CGROUPS)
> > M:	Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> > M:	Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> > L:	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> 
> Odd, my version has
> 
> L:      containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> L:      cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> 
> The cgroups entry was added in November 2011 according to git-blame.
> I don't know why the kernel.org version is so old.

Because when kernel.org got broken into they did a major  
barn-door-locking that took away everyone's account until you could get  
your key signed by senior kernel developers in person, and since I  
don't go to a lot of conferences I didn't manage that until February of  
this year.

Then when I got my account back, I found out that the ability to rsync  
over ssh had gone away and instead they've replaced shell access with a  
home-grown tool called "kup" (because as well all know, the way to  
secure a system is for non-security people to write their own tools  
from scratch). And unfortunately, that tool is basically "git access  
and afterthoughts".

It's theoretically possible to copy files through kup, one at a time,  
after individually cryptographically signing each file. It's also  
possible to list directories through kup. So what I need to do is write  
a shell script that traverses my local kdocs directory, lists the  
contents on the website, makes two trees, compares the trees, figures  
out which files need updating, signs each file and uploads it.

I.E. laboriously reimplementing a sad immitation of rsync through this  
insane bespoke tool.

It's on my todo list...

Rob

(P.S. yes I asked: the kernel developers do not care in the slightest  
that when the server changed out from under the users, their new tool  
does not match my existing workflow. And it's their server, they can do  
what they like. I'm just annoyed at the "department of homeland  
security" levels of disproportionate response, and that containers are  
still not considered worth using here.)
