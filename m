From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 00/11] pkg-shadow support subordinate ids with user
	namespaces
Date: Thu, 07 Mar 2013 14:56:00 -0800
Message-ID: <876212rf9b.fsf@xmission.com>
References: <87d2wxshu0.fsf@xmission.com> <20130307102352.4a5943cd@oracle.com>
	<20130307215457.GB9348@austin.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130307215457.GB9348-anj0Drq5vpzx6HRWoRZK3AC/G2K4zDHf@public.gmane.org> (Serge E. Hallyn's
	message of "Thu, 7 Mar 2013 15:54:57 -0600")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Pkg-shadow-devel-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org, "Michael Kerrisk
	(man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Nicolas =?utf-8?Q?Fran=C3=A7o?= =?utf-8?Q?is?= <nicolas.francois-Fa7rcPG4DJn7nK0/Xc0eeg@public.gmane.org>
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Dwight Engen (dwight.engen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org):
> ...
>> diff -ur shadow-4.1.5.1.orig/src/usermod.c shadow-4.1.5.1/src/usermod.c
>> --- shadow-4.1.5.1.orig/src/usermod.c	2013-03-06 16:20:53.872175769 -0500
>> +++ shadow-4.1.5.1/src/usermod.c	2013-03-06 16:53:17.560141517 -0500
>> @@ -410,9 +410,9 @@
>>  	(void) fputs (_("  -u, --uid UID                 new UID for the user account\n"), usageout);
>>  	(void) fputs (_("  -U, --unlock                  unlock the user account\n"), usageout);
>>  	(void) fputs (_("  -v, --add-subuids FIRST-LAST  add range of subordinate uids\n"), usageout);
>> -	(void) fputs (_("  -V, --del-subuids FIRST-LAST  remvoe range of subordinate uids\n"), usageout);
>> +	(void) fputs (_("  -V, --del-subuids FIRST-LAST  remove range of subordinate uids\n"), usageout);
>>  	(void) fputs (_("  -w, --add-subgids FIRST-LAST  add range of subordinate gids\n"), usageout);
>> -	(void) fputs (_("  -W, --del-subgids FIRST-LAST  remvoe range of subordinate gids\n"), usageout);
>> +	(void) fputs (_("  -W, --del-subgids FIRST-LAST  remove range of subordinate gids\n"), usageout);
>>  #ifdef WITH_SELINUX
>>  	(void) fputs (_("  -Z, --selinux-user SEUSER     new SELinux user mapping for the user account\n"), usageout);
>>  #endif				/* WITH_SELINUX */
>> @@ -993,9 +993,9 @@
>>  		};
>>  		while ((c = getopt_long (argc, argv,
>>  #ifdef WITH_SELINUX
>> -			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:UZ:",
>> +			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:Uv:V:w:W:Z:",
>>  #else				/* !WITH_SELINUX */
>> -			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:U",
>> +			                 "ac:d:e:f:g:G:hl:Lmop:R:s:u:Uv:V:w:W:",
>>  #endif				/* !WITH_SELINUX */
>>  			                 long_options, NULL)) != -1) {
>>  			switch (c) {
>
> This hunk I've already emailed to Eric :)  
> Note there is also a "break;" needed around line 1141.
>
> Great to see more people testing this.  Hopefully it will help to ease the
> mind of the maintainers in considering merging this.

Yes.  It looks like we are going to have to setup a public repository
somewhere to collect all of the changes and bug fixes.  Not that I
expect too many but clearly there are a few needed.

Sigh I was hoping shadow had an active mainter, and creating a public
feature branch would not have been necessary.

Eric
